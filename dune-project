(lang dune 3.10)
(name relic-store)
(version 0.1.0)
(cram enable)
(generate_opam_files true)
(source (github AoeCenter/relic-store))
(authors 
  "echo 'QW5kcmVhcyBLcsO8aGxtYW5uIDxhbmRyZWFzQGtydWhsbWFubi5kZXY+Cg==' | base64 -d")
(maintainers 
  "echo 'QW5kcmVhcyBLcsO8aGxtYW5uIDxhbmRyZWFzQGtydWhsbWFubi5kZXY+Cg==' | base64 -d")
(license MIT)
(documentation https://github.com/AoeCenter/relic-store)
(package
 (name relic-store)
 (synopsis "Relic link persistence with relic-sdk")
 (depends
  (ocaml
   (>= 4.14))
  (sqlite3
   (>= 5.1.0))
  (uuidm
   (>= 0.9.8))
  (alcotest
   (and
    :with-test
    (>= 1.3.0)))
  (alcotest-lwt
   (and
    :with-test
    (>= 1.7.0)))
  (bisect_ppx
   (and
    :with-test
    (>= 2.3.0)))
  (ocamlformat
   (and
    :with-dev-setup
    (>= 0.26.1)))
  (base
   (>= v0.12.0))
  (dune
    (>= 3.15.0))
  dune-build-info))
