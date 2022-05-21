#! /bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
REDBG='\e[41m'
GREENBG='\e[42m'
BLUEBG='\e[44m'
NC='\033[0m' # No Color

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
TESTS_OUTPUT=$SCRIPTPATH/outputs
TESTS_INPUTS=$SCRIPTPATH/ex1_tests
TESTS_EXPECTED=$SCRIPTPATH/ex1_tests
TESTER=$SCRIPTPATH/tester.out
CORES=`nproc --all`
TASKS=${TASKS:-$(( $CORES > 1 ? $CORES - 1 : 1 ))}
TESTS_GLOB=$TESTS_INPUTS/${1:-test_*}.in.txt

mkdir -p $TESTS_OUTPUT

for test in `ls $TESTS_GLOB | xargs -n 1 basename | sort -t _ -k 2 -g`; do
    while jobs=`jobs -p | wc -w` && [[ $jobs -ge $TASKS ]]; do
        sleep 0.1
        jobs > /dev/null # for some reason without this line the loop is sometimes infinite...
    done
    test=$(basename -- "$test" .in.txt)
    echo "Running test $test"
    $TESTER $TESTS_INPUTS/$test.in.txt > $TESTS_OUTPUT/$test.my_out.txt &
done


echo ""
echo ""
echo "Waiting for all jobs to complete"
while jobs=`jobs | wc -l` && [[ $jobs -gt 0 ]]; do
    sleep 0.1
    jobs > /dev/null # for some reason without this line the loop is sometimes infinite...
done



do_diff()
{
    status=0
    echo "#:TEST NAME:STDOUT\n"
    i=0
    for test in `ls $TESTS_GLOB | xargs -n 1 basename | sort -t _ -k 2 -g`; do
        test=$(basename -- "$test" .in.txt)
        output_result="${YELLOW}MISSING${NC}"
        if [ -f "$TESTS_EXPECTED/$test.out.txt" ]; then
            if [ "`diff -q --strip-trailing-cr $TESTS_INPUTS/$test.out.txt $TESTS_OUTPUT/$test.my_out.txt`" ]; then
                output_result="${RED}FAILED${NC}"
                if [ "$VSCODE_IPC_HOOK_CLI" ]; then
                    code --diff $TESTS_INPUTS/$test.out.txt $TESTS_OUTPUT/$test.my_out.txt
                    break
                fi
                status=1
            else
                output_result="${GREEN}PASSED${NC}"
            fi
        fi
        (( i++ ))
        echo "$i:$test:$output_result\n"
    done
    return $status
}

# now do diff
output="$(do_diff)"
status=$?
echo -e $output | column -t -s ":"

if [ $status -eq 0 ]; then
    echo -e "${GREENBG}ALL PASSED!${NC}"
    exit 0
else
    echo -e "${REDBG}FAILED${NC}"
    exit 1
fi
