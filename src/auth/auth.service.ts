import { SignupRequestDto } from './dto/signupRequest.dto';
import { Injectable } from '@nestjs/common';
import { AuthRepository } from './auth.repository';
import { SigninRequestDto } from './dto/signinRequestDto';
import { User } from '@firebase/auth';

@Injectable()
export class AuthService {
  constructor(private readonly authRepository: AuthRepository) {}

  signup(signupRequestDto: SignupRequestDto) {
    return this.authRepository.signup(signupRequestDto);
  }

  signin(signinRequestDto: SigninRequestDto) {
    return this.authRepository.signin(signinRequestDto);
  }

  confirmEmail(email: string) {
    return this.authRepository.confirmSigninEmail(email);
  }
}
