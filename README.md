# DBT-3

DBT-3 is a decision support benchmark driver for relational database systems. Data and workload are based on the TPC-H benchmark specification (http://www.tpc.org/tpch/), although the DBT-3 benchmark does not adhere to all TPC-H rules (e.g., creation of additional secondary index structures). This version of the DBT-3 benchmark is based on the original dbt3 repository that was last updated in 2012 (http://sourceforge.net/p/osdldbt/dbt3/ci/master/tree/). Changes were made such that DBT-3 is now able to run on newer versions of Ubuntu (14.04+), with newer versions of PostgreSQL (9.3+), and with the HyPer main-memory database sytem (http://www.hyper-db.com/). Additionally, refresh streams have been fixed (the previously used SQL syntax was wrong and error messages were discarded) and other minor glitches in the original implementation have been resolved. The repository still contains scripts for MySQL, but these scripts have not been updated yet.

## Howto (on Ubuntu with PostgreSQL and HyPer)

### Prerequisites
* Install PostgreSQL (9.3+)
```sh
sudo apt-get install postgresql-9.4
```
* Export postgresql binary path in your PATH (e.g., by adding the following statement to your .bashrc)
```sh
export PATH=$PATH:/usr/lib/postgresql/9.4/bin
```
* Download and unpack HyPer binaries
```sh
wget http://www-db.in.tum.de/~neumann/hyperdemo.tar.xz
tar xf hyperdemo.tar.xz
```
* Add bin folder of unpacked hyperdemo to your PATH (see PostgreSQL instruction above for reference)
* Install procmail (for lockfile command), autoconf, and gnuplot
```sh
sudo apt-get install procmail autoconf gnuplot
```

### Benchmarking steps

* Clone repository
```sh
git clone https://github.com/muehlbau/dbt3.git
```
* Cd to directory and run autogen.sh, configure (mind to set the correct postgresql lib path), and make
```sh
cd dbt3
./autogen.sh
./configure --with-postgresql=/usr/lib/postgresql/9.4
make
```
* Edit settings in scripts/dbt3_profile and scripts/pgsql/pgsql_profile; also make sure that the PGDATA exists.
* If you want to test HyPer, set USE_HYPER to 1:
```sh
USE_HYPER=1
```
If you  want to benchmark PostgreSQL, leave USE_HYPER at 0. Clear the PGDATA directory if you switch between PostgreSQL and HyPer.
* Generate TPC-H data (argument is scale factor), e.g., for scale factor 1:
```sh
scripts/gen_data.sh 1
```
* Run benchmark (-f is the scale factor argument), e.g., for scale factor 1:
```sh
scripts/dbt3-run-workload -f 1
```

### Troubleshooting

If anything goes wrong, the first thing to try is to clear your PGDATA (defined in scripts/pgsql/pgsql_profile) directory.

