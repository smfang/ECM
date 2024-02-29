import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
} from '@nestjs/common';
import { CarbonProjectsService } from './carbon-projects.service';
import { CreateCarbonProjectDto } from './dto/create-carbon-project.dto';
import { UpdateCarbonProjectDto } from './dto/update-carbon-project.dto';

@Controller('carbon-projects')
export class CarbonProjectsController {
  constructor(private readonly carbonProjectsService: CarbonProjectsService) {}

  @Post()
  create(@Body() createCarbonProjectDto: CreateCarbonProjectDto) {
    return this.carbonProjectsService.create(createCarbonProjectDto);
  }

  @Get()
  findAll() {
    return this.carbonProjectsService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.carbonProjectsService.findOne(+id);
  }

  @Patch(':id')
  update(
    @Param('id') id: string,
    @Body() updateCarbonProjectDto: UpdateCarbonProjectDto,
  ) {
    return this.carbonProjectsService.update(+id, updateCarbonProjectDto);
  }

  @Delete(':id')
  delete(@Param('id') id: number) {
    return this.carbonProjectsService.delete(id);
  }
}
