import { Module } from '@nestjs/common';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { AuthRepository } from './auth.repository';
import admin from 'firebase-admin';
import { UsersModule } from 'src/users/users.module';

// eslint-disable-next-line @typescript-eslint/no-var-requires
const serviceAccount = require('./configAuth.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

@Module({
  imports: [UsersModule],
  controllers: [AuthController],
  providers: [AuthService, AuthRepository],
})
export class AuthModule {}
