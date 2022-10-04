ARG REPO=mcr.microsoft.com/dotnet/core
FROM $REPO/aspnet:6-buster-slim AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM $REPO/sdk:6-buster AS build
ENV BuildingDocker true
WORKDIR /src
COPY ["Project1.csproj", ""]
RUN dotnet restore "Project1.sln"
COPY . .
WORKDIR "/src"
RUN dotnet build "Project1/Project1.csproj" -c Release -o /app/build

FROM node:12-alpine as build-node
WORKDIR ClientApp
COPY ClientApp/package.json .
COPY ClientApp/package-lock.json .
RUN npm install
COPY ClientApp/ .
RUN npm run-script build

FROM build AS publish
RUN dotnet publish "Project1/Project1.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
COPY --from=build-node /ClientApp/dist ./ClientApp/dist
CMD ASPNETCORE_URLS=http://*:$PORT dotnet Project1.dll