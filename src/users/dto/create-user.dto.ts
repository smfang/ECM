import { IsEmail, IsNotEmpty } from 'class-validator';

export class CreateUserDto {
  @IsNotEmpty()
  firebaseId: string;

  @IsNotEmpty()
  name: string;

  @IsEmail()
  emailAddress: string;

  @IsNotEmpty()
  password: string;
}
