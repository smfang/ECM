import { Injectable } from '@nestjs/common';
import { CreateCarbonProjectDto } from './dto/create-carbon-project.dto';
import { UpdateCarbonProjectDto } from './dto/update-carbon-project.dto';
import { CarbonProjectsRepository } from './carbon-projects.repository';

@Injectable()
export class CarbonProjectsService {
  constructor(
    private readonly carbonProjectsRepository: CarbonProjectsRepository,
  ) {}

  create(carbonProject: CreateCarbonProjectDto) {
    return this.carbonProjectsRepository.create(carbonProject);
  }

  findAll() {
    return this.carbonProjectsRepository.find({});
  }

  findOne(id: number) {
    return this.carbonProjectsRepository.findOne({ id });
  }

  update(id: number, updateCarbonProjectDto: UpdateCarbonProjectDto) {
    return this.carbonProjectsRepository.findOneAndUpdate(
      updateCarbonProjectDto,
      { id },
    );
  }

  delete(id: number) {
    return this.carbonProjectsRepository.delete(id);
  }
}
