# Dockerfile for C++ Cloud Run microservice
FROM gcc:13.2.0 as build
WORKDIR /app
COPY . .
RUN mkdir -p external && \
    curl -L https://github.com/yhirose/cpp-httplib/raw/master/httplib.h -o external/httplib.h && \
    g++ -std=c++17 -O2 -o cpp_service main.cpp

FROM debian:bookworm-slim
WORKDIR /app
COPY --from=build /app/cpp_service /app/
EXPOSE 8080
CMD ["/app/cpp_service"]
