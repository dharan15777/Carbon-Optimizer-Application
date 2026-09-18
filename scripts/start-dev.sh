#!/usr/bin/env bash
set -Eeuo pipefail

# Start both local applications from the repository root.  In particular, Maven
# must be invoked with carbonwise-backend as its working directory; running the
# command from the repository root makes Maven unable to resolve the Boot plugin.
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKEND_DIR="$ROOT_DIR/carbonwise-backend"
MOBILE_DIR="$ROOT_DIR/carbonwise-mobile"

if [[ ! -f "$BACKEND_DIR/pom.xml" ]]; then
  echo "Backend pom.xml not found at $BACKEND_DIR" >&2
  exit 1
fi

if ! command -v mvn >/dev/null 2>&1; then
  echo "Maven is required. Install Maven (and Java 17+) before starting CarbonWise." >&2
  exit 1
fi

if [[ "$(basename "$PWD")" != "carbonwise-backend" ]]; then
  echo "Starting backend from: $BACKEND_DIR"
fi

# Keep this cd immediately next to the Maven command so the command cannot be
# accidentally run from the workspace root.
(
  cd "$BACKEND_DIR"
  exec mvn spring-boot:run
) &
BACKEND_PID=$!

cleanup() {
  kill "$BACKEND_PID" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

echo "Backend starting on http://localhost:8080 (PID $BACKEND_PID)"
for _ in {1..60}; do
  if curl -fsS http://localhost:8080/actuator/health >/dev/null 2>&1 || \
     curl -fsS http://localhost:8080/health >/dev/null 2>&1 || \
     (command -v nc >/dev/null 2>&1 && nc -z localhost 8080 >/dev/null 2>&1); then
    echo "Backend is listening on port 8080."
    break
  fi
  if ! kill -0 "$BACKEND_PID" 2>/dev/null; then
    echo "Backend stopped before port 8080 became available." >&2
    exit 1
  fi
  sleep 2
done

if ! (command -v nc >/dev/null 2>&1 && nc -z localhost 8080 >/dev/null 2>&1) && \
   ! curl -fsS http://localhost:8080/actuator/health >/dev/null 2>&1 && \
   ! curl -fsS http://localhost:8080/health >/dev/null 2>&1; then
  echo "Timed out waiting for backend port 8080." >&2
  exit 1
fi

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter is not installed; backend is running, but the mobile frontend was not started." >&2
  wait "$BACKEND_PID"
fi

cd "$MOBILE_DIR"
flutter pub get
exec flutter run
