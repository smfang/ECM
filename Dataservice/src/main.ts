import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableCors();
  await app.listen(3000);
  const appUrl = await app.getUrl();
  console.log(`App started on url ${appUrl}`);
}
bootstrap();
