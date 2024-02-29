import { SignupRequestDto } from './dto/signupRequest.dto';
import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { FilterQuery, Model } from 'mongoose';
import admin from 'firebase-admin';
import { UserRecord } from 'firebase-admin/lib/auth/user-record';
import { UsersService } from 'src/users/users.service';
import { SigninRequestDto } from './dto/signinRequestDto';
import {
  User,
  applyActionCode,
  getAuth,
  sendEmailVerification,
  sendSignInLinkToEmail,
} from 'firebase/auth';
import { auth } from './auth';

@Injectable()
export class AuthRepository {
  constructor(private readonly userService: UsersService) {}

  async signup(signupRequestDto: SignupRequestDto): Promise<UserRecord> {
    try {
      const userResponse = await admin.auth().createUser(signupRequestDto);
      if (userResponse !== null || userResponse !== undefined) {
        this.userService.create({
          firebaseId: userResponse.uid,
          name: userResponse.email,
          emailAddress: userResponse.email,
          password: userResponse.passwordHash,
        });
        return userResponse;
      }
    } catch (error) {
      throw new Error(error);
    }
  }

  async signin(signinRequestDto: SigninRequestDto): Promise<UserRecord> {
    try {
      const user = await admin.auth().getUserByEmail(signinRequestDto.email);
      console.log(user.passwordHash);
      if (user !== null || user !== undefined) {
        return user;
      }
    } catch (error) {
      throw new Error(error);
    }
  }

  async confirmSigninEmail(email: string): Promise<any> {
    const actionCodeSettings = {
      url: 'https://www.example.com/?email=user@example.com',
      iOS: {
        bundleId: 'com.example.ios',
      },
      android: {
        packageName: 'com.example.android',
        installApp: true,
        minimumVersion: '12',
      },
      handleCodeInApp: true,
    };
    try {
      sendSignInLinkToEmail(auth, email, actionCodeSettings).then(() => {
        console.log('Email sent !');
      });
    } catch (error) {
      throw new Error(error);
    }
  }

  async getUser(email: string): Promise<UserRecord> {
    try {
      const user = await admin.auth().getUserByEmail(email);
      if (user !== null || user !== undefined) {
        return user;
      }
    } catch (error) {
      throw new Error(error);
    }
  }

  async getCurrentUser(email: string): Promise<User> {
    try {
      const user = auth.currentUser;
      if (user !== null || user !== undefined) {
        return user;
      }
    } catch (error) {
      throw new Error(error);
    }
  }
}
