import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { FilterQuery, Model } from 'mongoose';
import { Admin, AdminDocument } from './schemas/admin.schema';

@Injectable()
export class AdminRepository {
  constructor(
    @InjectModel(Admin.name)
    private adminModel: Model<AdminDocument>,
  ) {}

  async findOne(carbonProjectFilterQuery: FilterQuery<Admin>): Promise<Admin> {
    return this.adminModel.findOne(carbonProjectFilterQuery);
  }

  async find(carbonProjectFilterQuery: FilterQuery<Admin>): Promise<Admin[]> {
    return this.adminModel.find(carbonProjectFilterQuery);
  }

  async create(carbonProject: Admin): Promise<Admin> {
    const newUser = new this.adminModel(carbonProject);
    return newUser.save();
  }

  async delete(id: number): Promise<any> {
    this.adminModel.deleteOne({ id });
    return true;
  }

  async findOneAndUpdate(
    carbonProjectFilterQuery: FilterQuery<Admin>,
    carbonProject: Partial<Admin>,
  ): Promise<Admin> {
    return this.adminModel.findOneAndUpdate(
      carbonProjectFilterQuery,
      carbonProject,
    );
  }
}
