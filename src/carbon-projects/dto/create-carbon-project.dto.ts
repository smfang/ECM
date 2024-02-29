import { IsEmail, IsNotEmpty } from 'class-validator';

export class CreateCarbonProjectDto {
  @IsNotEmpty()
  id: number;

  @IsNotEmpty()
  name: string;

  @IsNotEmpty()
  address: string;
}
