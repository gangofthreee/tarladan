package com.gangofthree.tarladan.modules.user.service;

import com.gangofthree.tarladan.modules.customer.repository.CustomerRepository;
import com.gangofthree.tarladan.modules.depotOwner.repository.DepotOwnerRepository;
import com.gangofthree.tarladan.modules.farmer.repository.FarmerRepository;
import com.gangofthree.tarladan.modules.trucker.repository.TruckerRepository;
import com.gangofthree.tarladan.modules.user.entity.User;
import org.springframework.stereotype.Service;

@Service
public class RoleBasedIdService {

    private final FarmerRepository farmerRepository;
    private final CustomerRepository customerRepository;
    private final TruckerRepository truckerRepository;
    private final DepotOwnerRepository depotOwnerRepository;

    public RoleBasedIdService(FarmerRepository farmerRepository, CustomerRepository customerRepository, TruckerRepository truckerRepository, DepotOwnerRepository depotOwnerRepository) {
        this.farmerRepository = farmerRepository;
        this.customerRepository = customerRepository;
        this.truckerRepository = truckerRepository;
        this.depotOwnerRepository = depotOwnerRepository;
    }

    public Long getDomainId(User user) {
        return switch (user.getRole()) {
            case FARMER -> farmerRepository.findByUser_Id(user.getId())
                    .map(farmer -> farmer.getId())
                    .orElseThrow(() -> new IllegalStateException("Farmer entity not found for user: " + user.getId()));
            case CUSTOMER -> customerRepository.findByUser_Id(user.getId())
                    .map(customer -> customer.getId())
                    .orElseThrow(() -> new IllegalStateException("Customer entity not found for user: " + user.getId()));
            case TRUCKER -> truckerRepository.findByUser_Id(user.getId())
                    .map(trucker -> trucker.getId())
                    .orElseThrow(() -> new IllegalStateException("Trucker entity not found for user: " + user.getId()));
            case DEPOT_OWNER -> depotOwnerRepository.findByUser_Id(user.getId())
                    .map(owner -> owner.getId())
                    .orElseThrow(() -> new IllegalStateException("DepotOwner entity not found for user: " + user.getId()));
            default -> throw new IllegalArgumentException("Unsupported User Role for Domain ID search: " + user.getRole());
        };
    }
}
