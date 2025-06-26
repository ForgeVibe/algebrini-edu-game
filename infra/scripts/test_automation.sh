#!/bin/bash
set -e

# Configuration
IMAGE_NAME=algebrini-flutter
FLUTTER_VERSION=3.19.6
FLUTTER_TAR="flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/${FLUTTER_TAR}"
DOCKER_CONTEXT="../docker"
DOWNLOADS_DIR="../downloads"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}🧪 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  dev, development    Build and run in development mode (default)"
    echo "  test                Run all tests with coverage"
    echo "  build-web           Build web app for production"
    echo "  build-android       Build Android APK"
    echo "  serve-web           Serve built web app with nginx"
    echo "  clean               Clean Docker images and containers"
    echo "  ci                  CI/CD mode (run tests and build web)"
    echo "  help                Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 dev              # Development mode"
    echo "  $0 test             # Run tests"
    echo "  $0 build-web        # Build for production"
    echo "  $0 ci               # CI/CD pipeline"
}

# Function to download Flutter SDK if needed
download_flutter() {
    if [ ! -f "${DOWNLOADS_DIR}/${FLUTTER_TAR}" ]; then
        print_status "Downloading Flutter SDK archive..."
        mkdir -p "${DOWNLOADS_DIR}"
        wget -O "${DOWNLOADS_DIR}/${FLUTTER_TAR}" "$FLUTTER_URL" || { print_error "Download failed"; exit 1; }
        print_success "Flutter SDK downloaded: $FLUTTER_TAR"
    else
        print_success "Flutter SDK archive already present: $FLUTTER_TAR"
    fi
}

# Function to build Docker image
build_image() {
    local target=${1:-development}
    print_status "Building Docker image for target: $target"
    docker build --build-arg FLUTTER_TAR=$FLUTTER_TAR --target $target -t $IMAGE_NAME:$target $DOCKER_CONTEXT
    print_success "Docker image built: $IMAGE_NAME:$target"
}

# Function to run development mode
run_development() {
    print_status "Starting development server..."
    docker run --rm -p 5000:5000 -p 8080:8080 $IMAGE_NAME:development
}

# Function to run tests
run_tests() {
    print_status "Running tests with coverage..."
    docker run --rm $IMAGE_NAME:testing
    print_success "Tests completed"
}

# Function to build web app
build_web() {
    print_status "Building web app for production..."
    docker build --build-arg FLUTTER_TAR=$FLUTTER_TAR --target web-build -t $IMAGE_NAME:web-build $DOCKER_CONTEXT
    print_success "Web app built successfully"
}

# Function to build Android APK
build_android() {
    print_warning "Android builds require additional setup and may not work in all environments"
    print_status "Building Android APK..."
    docker build --build-arg FLUTTER_TAR=$FLUTTER_TAR --target android-build -t $IMAGE_NAME:android-build $DOCKER_CONTEXT
    print_success "Android APK built successfully"
}

# Function to serve web app
serve_web() {
    print_status "Building production web server..."
    docker build --build-arg FLUTTER_TAR=$FLUTTER_TAR --target production -t $IMAGE_NAME:production $DOCKER_CONTEXT
    print_status "Starting production web server..."
    docker run --rm -p 80:80 $IMAGE_NAME:production
}

# Function to clean up
clean_up() {
    print_status "Cleaning up Docker resources..."
    docker system prune -f
    docker rmi $IMAGE_NAME:development $IMAGE_NAME:testing $IMAGE_NAME:web-build $IMAGE_NAME:android-build $IMAGE_NAME:production 2>/dev/null || true
    print_success "Cleanup completed"
}

# Function to run CI/CD pipeline
run_ci() {
    print_status "Running CI/CD pipeline..."
    
    # Run tests
    run_tests
    
    # Build web app
    build_web
    
    # Build Android APK
    build_android
    
    print_success "CI/CD pipeline completed successfully"
}

# Main script logic
main() {
    local action=${1:-dev}
    
    case $action in
        dev|development)
            print_status "Algebrini Flutter Development Environment"
            download_flutter
            build_image development
            run_development
            ;;
        test)
            print_status "Algebrini Flutter Testing"
            download_flutter
            build_image testing
            run_tests
            ;;
        build-web)
            print_status "Algebrini Flutter Web Build"
            download_flutter
            build_web
            ;;
        build-android)
            print_status "Algebrini Flutter Android Build"
            download_flutter
            build_android
            ;;
        serve-web)
            print_status "Algebrini Flutter Web Server"
            download_flutter
            serve_web
            ;;
        clean)
            clean_up
            ;;
        ci)
            print_status "Algebrini Flutter CI/CD Pipeline"
            download_flutter
            run_ci
            ;;
        help|--help|-h)
            show_usage
            ;;
        *)
            print_error "Unknown option: $action"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
