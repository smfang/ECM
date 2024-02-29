import { Injectable } from '@nestjs/common';
import { CreateAdminDto } from './dto/create-admin.dto';
import { UpdateAdminDto } from './dto/update-admin.dto';
import { AdminRepository } from './admins.repository';

@Injectable()
export class AdminsService {
  constructor(private readonly adminRepository: AdminRepository) {}

  create(createAdminDto: CreateAdminDto) {
    return this.adminRepository.create(createAdminDto);
  }

  findAll() {
    return this.adminRepository.find({});
  }

  findOne(id: number) {
    return this.adminRepository.findOne({ id });
  }

  update(id: number, updateAdminDto: UpdateAdminDto) {
    return this.adminRepository.findOneAndUpdate(updateAdminDto, { id });
  }

  delete(id: number) {
    return this.adminRepository.delete(id);
  }
}
