package com.carbonwise.repository;

import com.carbonwise.entity.City;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface CityRepository extends JpaRepository<City, String> {
}
