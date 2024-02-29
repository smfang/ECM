import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
} from '@nestjs/common';
import { SignupRequestDto } from './dto/signupRequest.dto';
import { AuthService } from './auth.service';
import { SigninRequestDto } from './dto/signinRequestDto';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('/signup')
  signup(@Body() signupRequest: SignupRequestDto) {
    return this.authService.signup(signupRequest);
  }

  @Post('/signin')
  signin(@Body() signinRequest: SigninRequestDto) {
    return this.authService.signin(signinRequest);
  }

  @Post('/confirmEmail')
  confirmEmail(@Body() body: { email }) {
    return this.authService.confirmEmail(body.email);
  }
}
