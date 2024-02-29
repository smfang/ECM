import { PartialType } from '@nestjs/mapped-types';
import { CreateCarbonProjectDto } from './create-carbon-project.dto';

export class UpdateCarbonProjectDto extends PartialType(
  CreateCarbonProjectDto,
) {}
