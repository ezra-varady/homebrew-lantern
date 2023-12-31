class Lantern < Formula
  desc "Is a postgres extension that provides blazingly fast vector indexes"
  homepage "https://lantern.dev"
  url "https://github.com/lanterndata/lantern/archive/refs/tags/v0.0.4.tar.gz"
  version "0.0.4"
  sha256 "00fa1048d435ff20a61100e9ab40929739c35ecb67f6c93c38db252d4fe4cac9"

  license "MIT"

  depends_on "cmake" => :build
  depends_on "gcc" => :build
  depends_on "postgresql"

  def install
    ENV["C_INCLUDE_PATH"] = "/usr/local/include"
    ENV["CPLUS_INCLUDE_PATH"] = "/usr/local/include"
    system "cmake", "-S", ".", "-B", "build"
    system "make", "-C", "build", "install"
  end

  def postgresql
    Formula["postgresql"]
  end

  test do
    pg_ctl = postgresql.opt_bin/"pg_ctl"
    psql = postgresql.opt_bin/"psql"
    port = free_port

    system pg_ctl, "initdb", "-D", testpath/"test"
    (testpath/"test/postgresql.conf").write <<~EOS, mode: "a+"

      shared_preload_libraries = 'lantern'
      port = #{port}
    EOS
    system pg_ctl, "start", "-D", testpath/"test", "-l", testpath/"log"
    system psql, "-p", port.to_s, "-c", "CREATE EXTENSION \"lantern\";", "postgres"
    system pg_ctl, "stop", "-D", testpath/"test"
  end
end
