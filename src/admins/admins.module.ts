import { Module } from '@nestjs/common';
import { AdminsService } from './admins.service';
import { AdminsController } from './admins.controller';
import { MongooseModule } from '@nestjs/mongoose';
import { Admin } from './entities/admin.entity';
import { AdminSchema } from './schemas/admin.schema';
import { AdminRepository } from './admins.repository';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: Admin.name, schema: AdminSchema }]),
  ],
  controllers: [AdminsController],
  providers: [AdminsService, AdminRepository],
})
export class AdminsModule {}
