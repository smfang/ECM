import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument } from 'mongoose';

export type UserDocument = HydratedDocument<User>;

@Schema()
export class User {
  @Prop({ required: true })
  firebaseId: string;

  @Prop({ required: true })
  name: string;

  @Prop({ required: true })
  emailAddress: string;
}

export const UserSchema = SchemaFactory.createForClass(User);
