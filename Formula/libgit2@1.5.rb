class Libgit2AT15 < Formula
  desc "C library of Git core methods that is re-entrant and linkable"
  homepage "https://libgit2.org/"
  url "https://github.com/libgit2/libgit2/archive/refs/tags/v1.5.2.tar.gz"
  sha256 "57638ac0e319078f56a7e17570be754515e5b1276d3750904b4214c92e8fa196"
  license "GPL-2.0-only" => { with: "GCC-exception-2.0" }
  head "https://github.com/libgit2/libgit2.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/jacktonkin/homebrew-tap/releases/download/libgit2@1.5-1.5.2"
    sha256 cellar: :any, arm64_tahoe:  "efb7ecba96beb2c527af4b857c5ba1531c4fc8f97188d12b099ee59500de7e35"
    sha256 cellar: :any, sequoia:      "e53e4cec0cedf91f0c187f2cb3f99d8b6ccf0a85e8b55c93eef293313d039fe5"
    sha256 cellar: :any, x86_64_linux: "c50a7bb65809c7c17f93f67cd084b401da90827a2930b1abbf959d8a8139c2cb"
  end

  keg_only :versioned_formula

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "libssh2"

  on_linux do
    depends_on "openssl@3" # Uses SecureTransport on macOS
    depends_on "zlib-ng-compat"
  end

  def install
    args = std_cmake_args
    args << "-DBUILD_EXAMPLES=OFF"
    args << "-DBUILD_TESTS=OFF" # Don't build tests.
    args << "-DUSE_SSH=YES"

    mkdir "build" do
      system "cmake", "..", *args
      system "make", "install"
      system "make", "clean"
      system "cmake", "..", "-DBUILD_SHARED_LIBS=OFF", *args
      system "make"
      lib.install "libgit2.a"
    end
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <git2.h>
      #include <assert.h>

      int main(int argc, char *argv[]) {
        int options = git_libgit2_features();
        assert(options & GIT_FEATURE_SSH);
        return 0;
      }
    EOS
    libssh2 = Formula["libssh2"]
    flags = %W[
      -I#{include}
      -I#{libssh2.opt_include}
      -L#{lib}
      -lgit2
    ]
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
  end
end
