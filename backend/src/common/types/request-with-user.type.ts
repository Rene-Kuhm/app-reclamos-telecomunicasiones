import { Request } from 'express';
import { Usuario } from '@prisma/client';

export interface RequestWithUser extends Request {
  user: Usuario;
}

export interface JwtPayload {
  sub: string;
  email: string;
  roles: string[];
  iat?: number;
  exp?: number;
}

export interface RefreshTokenPayload extends JwtPayload {
  refreshToken?: string;
}