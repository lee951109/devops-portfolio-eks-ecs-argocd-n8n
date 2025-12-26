# Node.js 20 LTS 기반 이미지
FROM node:20-alpine

# 컨테이너 내부 작업 디렉터리
WORKDIR /app

# package.json 먼저 복사 (Docker Layer Cache 최적화)
COPY package.json package-lock.json* ./

# 운영 환경 기준 의존성 설치
RUN npm install --production

# 애플리케이션 소스 복사
COPY src ./src

# 컨테이너가 사용할 포트
EXPOSE 8080

# 컨테이너 시작 시 실행 명령
CMD ["node", "src/server.js"]
