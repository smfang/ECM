import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument } from 'mongoose';

export type CarbonProjectDocument = HydratedDocument<CarbonProject>;

@Schema()
export class CarbonProject {
  @Prop({ required: true })
  id: number;

  @Prop({ required: true })
  name: string;

  @Prop({ required: true })
  address: string;
}

export const CarbonProjectSchema = SchemaFactory.createForClass(CarbonProject);
