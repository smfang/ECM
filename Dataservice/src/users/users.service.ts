import { Injectable } from '@nestjs/common';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { UsersRepository } from './users.repository';

@Injectable()
export class UsersService {
  constructor(private readonly usersRepository: UsersRepository) {}

  create(createUserDto: CreateUserDto) {
    return this.usersRepository.create(createUserDto);
  }

  findAll() {
    return this.usersRepository.find({});
  }

  findOne(id: number) {
    return this.usersRepository.findOne({ id });
  }

  update(id: string, updateUserDto: UpdateUserDto) {
    return this.usersRepository.findOneAndUpdate(updateUserDto, {
      firebaseId: id,
    });
  }

  delete(id: string) {
    return this.usersRepository.delete(id);
  }
}
