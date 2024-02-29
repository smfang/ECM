import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { FilterQuery, Model } from 'mongoose';
import {
  CarbonProject,
  CarbonProjectDocument,
} from './schemas/carbon-project.schema';

@Injectable()
export class CarbonProjectsRepository {
  constructor(
    @InjectModel(CarbonProject.name)
    private carbonProjectModel: Model<CarbonProjectDocument>,
  ) {}

  async findOne(
    carbonProjectFilterQuery: FilterQuery<CarbonProject>,
  ): Promise<CarbonProject> {
    return this.carbonProjectModel.findOne(carbonProjectFilterQuery);
  }

  async find(
    carbonProjectFilterQuery: FilterQuery<CarbonProject>,
  ): Promise<CarbonProject[]> {
    return this.carbonProjectModel.find(carbonProjectFilterQuery);
  }

  async create(carbonProject: CarbonProject): Promise<CarbonProject> {
    const newUser = new this.carbonProjectModel(carbonProject);
    return newUser.save();
  }

  async delete(id: number): Promise<any> {
    this.carbonProjectModel.deleteOne({ id });
    return true;
  }

  async findOneAndUpdate(
    carbonProjectFilterQuery: FilterQuery<CarbonProject>,
    carbonProject: Partial<CarbonProject>,
  ): Promise<CarbonProject> {
    return this.carbonProjectModel.findOneAndUpdate(
      carbonProjectFilterQuery,
      carbonProject,
    );
  }
}
