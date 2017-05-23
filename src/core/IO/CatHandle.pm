my class IO::CatHandle is IO::Handle {
    has @!handles;
    has IO::Handle $!active-handle;

    has $.path;
    has $.chomp is rw;
    has $.nl-in;
    has str $.encoding;

    method new (*@handles, :$pre-open-all,
        :$chomp = True, :$nl-in = ["\x0A", "\r\n"], :$encoding = 'utf8',
    ) {
        if $pre-open-all {
            for @handles {
                when IO::Handle {
                    next if .opened;
                    $_ = .open: :r, :$chomp, :$nl-in, :$encoding orelse .throw;
                }
                $_ = .IO.open: :r, :$chomp, :$nl-in, :$encoding orelse .throw;
            }
        }
        $_ := self.bless: :@handles, :$chomp, :$nl-in, :$encoding;
        .next-handle;
        $_
    }
    method next-handle {
      # Set $!active-handle to the next handle in line, opening it if necessary
      nqp::if(
        @handles,
        nqp::if(
          nqp::istype(($_ := @handles.shift), IO::Handle),
          nqp::if(
            .opened,
            ($!active-handle = $_),
            nqp::if(
              nqp::istype(
                ($!active-handle = .open: :r, :$!chomp, :$!nl-in, :$!encoding),
                Failure),
              .throw,
              $_)),
          nqp::if(
            nqp::istype(($_ := .IO.open: :r, :$!chomp, :$!nl-in, :$!encoding),
              Failure),
            .throw,
            $_),
        ($!active-handle = Nil))
    }

    # Produce a Seq with an iterator that walks through all handles
    method comb (::?CLASS:D: |c) {}
    method split (::?CLASS:D: |c) {}
    method words (::?CLASS:D: |c) {}
    method lines (::?CLASS:D: |c) {
        $!active-handle.DEFINITE
          ??
        flat gather {
            takeself!CALL-ON-ACTIVE("lines", NoHandle, |c
            nqp::while
        }
    }

    method Supply (::?CLASS:D: |c) {}

    # Get a single result, going to the next handle on EOF
    method get (::?CLASS:D: |c) {}
    method getc (::?CLASS:D: |c) {}
    method read (::?CLASS:D: |c) {}
    method readchars (::?CLASS:D: |c) {}

    # Walk through all handles, producing single result
    method slurp (::?CLASS:D: |c) {

    }
    method slurp-rest (|) {
        # We inherit deprecated .slurp-rest from IO::Handle. Pull the
        # plug on it in this class, since no one is using this yet.
        # The old IO::ArgFiles used .slurp
        die X::Obsolete.new: :old<slurp-rest>, :new<slurp>,
            :when('with IO::CatHandle')
    }
    method DESTROY {
        try .close for @!handles
    }

    # Call on current handle and do NOT switch to the next one
    method close    {}
    method encoding {}
    method eof      {}
    method gist     {}
    method Str      {}
    method IO       {}
    method path     {}
    method open     {}
    method opened   {}
    method lock     {}
    method nl-in    {}
    method Str      {}
    method seek     {}
    method tell     {}
    method t        {}
    method unlock   {}
    method native-descriptor {}

    #                        __________________________________________
    #                       / I don't know what the write methods      \
    #                      | should do in a CatHandle, so I'll mark    |
    #                      | these as NYI, for now.... Has anyone      |
    #                      \ seen my cocoon? I always lose that thing! /
    #                      |  -----------------------------------------
    #                      | /
    #                      |/
    #                    (⛣)
    proto method flush   (|) { * }
    multi method flush   (|) { die X::NYI.new: :feature<flush>    }
    proto method nl-out  (|) { * }
    multi method nl-out  (|) { die X::NYI.new: :feature<nl-out>   }
    proto method print   (|) { * }
    multi method print   (|) { die X::NYI.new: :feature<print>    }
    proto method print-nl(|) { * }
    multi method print-nl(|) { die X::NYI.new: :feature<print-nl> }
    proto method put     (|) { * }
    multi method put     (|) { die X::NYI.new: :feature<put>      }
    proto method say     (|) { * }
    multi method say     (|) { die X::NYI.new: :feature<say>      }
    proto method write   (|) { * }
    multi method write   (|) { die X::NYI.new: :feature<write>    }
    #                    /|\
}

# vim: ft=perl6 expandtab sw=4
