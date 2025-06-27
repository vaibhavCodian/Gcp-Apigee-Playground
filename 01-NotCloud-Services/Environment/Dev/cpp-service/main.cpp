// Simple C++ REST microservice using cpp-httplib
#include "httplib.h"
#include <iostream>
#include <cstdlib>

int main() {
    httplib::Server svr;

    svr.Get("/health", [](const httplib::Request&, httplib::Response& res) {
        res.set_content("{\"status\": \"ok\"}", "application/json");
    });

    svr.Get("/compute", [](const httplib::Request& req, httplib::Response& res) {
        // Example: return a simple computation result
        int a = 2, b = 3;
        int sum = a + b;
        res.set_content("{\"result\": " + std::to_string(sum) + "}", "application/json");
    });

    // Listen on port 8080 for Cloud Run compatibility
    std::cout << "C++ service running on port 8080..." << std::endl;
    svr.listen("0.0.0.0", 8080);
    return 0;
}
