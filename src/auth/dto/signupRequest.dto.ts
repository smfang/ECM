import { IsEmail, IsNotEmpty } from 'class-validator';

export class SignupRequestDto {
  @IsEmail()
  email: string;

  @IsNotEmpty()
  password: string;

  emailVerified: boolean;

  disabled: boolean;
}
