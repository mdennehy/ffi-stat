module FFI::Stat
  module Native
    extend FFI::Library

    ffi_lib FFI::Library::LIBC

    # Note that in Linux, the stat() functions are staticly linked and not in
    # libc.so.6 but in libc_unshared.a which FFI can't access as it's a static
    # library; instead we have to directly use the xstat() family of functions
    # and supply a version parameter at the start (which is usually 0 but check
    # your /usr/include/bits/stat.h to be sure).

    attach_function :stat,  :__xstat,  [ :int, :string, :pointer ], :int
    attach_function :lstat, :__lxstat, [ :int, :string, :pointer ], :int
    attach_function :fstat, :__fxstat, [ :int, :int,    :pointer ], :int
  end

  class Timespec < FFI::Struct
    layout :tv_sec,  :time_t,
           :tv_nsec, :long
  end

  class Stat < FFI::Struct
    layout :st_dev,     :dev_t,
           :st_ino,     :ino_t,
           :st_nlink,   :nlink_t,
           :st_mode,    :mode_t,
           :st_uid,     :uid_t,
           :st_gid,     :gid_t,
           :__pad0,     :int,
           :st_rdev,    :dev_t,
           :st_size,    :off_t,
           :st_blksize, :blksize_t,
           :st_blocks,  :blkcnt_t,
           :st_atimespec, FFI::Stat::Timespec,
           :st_mtimespec, FFI::Stat::Timespec,
           :st_ctimespec, FFI::Stat::Timespec,
           :__unused0,   :long,
           :__unused1,   :long,
           :__unused2,   :long,
           :__unused3,   :long,
           :__unused4,   :long
  end

  # Note that (confusingly) these are all in Octal, not Hexadecimal.

  # File types.
  S_IFMT   = 0o170000
  S_IFIFO  = 0o010000
  S_IFCHR  = 0o020000
  S_IFDIR  = 0o040000
  S_IFBLK  = 0o060000
  S_IFREG  = 0o100000
  S_IFLNK  = 0o120000
  S_IFSOCK = 0o140000

  # File modes.

  # Read, write, execute by owner.
  S_IRWXU  = 0o000700
  S_IRUSR  = 0o000400
  S_IWUSR  = 0o000200
  S_IXUSR  = 0o000100

  # Read, write, execute by group.
  S_IRWXG  = 0o000070
  S_IRGRP  = 0o000040
  S_IWGRP  = 0o000020
  S_IXGRP  = 0o000010

  # Read, write, execute by others.
  S_IRWXO  = 0o000007
  S_IROTH  = 0o000004
  S_IWOTH  = 0o000002
  S_IXOTH  = 0o000001

  S_ISUID  = 0o004000
  S_ISGID  = 0o002000
  S_ISVTX  = 0o001000

  def self.stat(path)
    stat = FFI::Stat::Stat.new

    FFI::Stat::Native.stat(0, path, stat.pointer)

    stat
  end

  def self.lstat(path)
    stat = FFI::Stat::Stat.new

    FFI::Stat::Native.lstat(0, path, stat.pointer)

    stat
  end

  def self.fstat(fd)
    stat = FFI::Stat::Stat.new

    FFI::Stat::Native.fstat(0, fd, stat.pointer)

    stat
  end
end
