import { Module } from '@nestjs/common';
import { CarbonProjectsService } from './carbon-projects.service';
import { CarbonProjectsController } from './carbon-projects.controller';
import { MongooseModule } from '@nestjs/mongoose';
import { CarbonProjectSchema } from './schemas/carbon-project.schema';
import { CarbonProjectsRepository } from './carbon-projects.repository';
import { CarbonProject } from './entities/carbon-project.entity';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: CarbonProject.name, schema: CarbonProjectSchema },
    ]),
  ],
  controllers: [CarbonProjectsController],
  providers: [CarbonProjectsService, CarbonProjectsRepository],
})
export class CarbonProjectsModule {}
