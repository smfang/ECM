import { IsEmail, IsNotEmpty } from 'class-validator';

export class CreateAdminDto {
  @IsNotEmpty()
  id: number;

  @IsNotEmpty()
  name: string;

  @IsEmail()
  emailAddress: string;
}
