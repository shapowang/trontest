const TYPE = 6;
const TOTAL = 6 ** 3;
let smallCount = 0, oddCount = 0, bigCount = 0, evenCount = 0, guessNumber = 0, threeSame = 0;
let statsObj = {};
for (let i = 1; i <= TYPE; i++) {
    for (let j = 1; j <= TYPE; j++) {
        for (let k = 1; k <= TYPE; k++) {
            let sum = i + j + k;
            //小，1赔1
            if (sum >= 4 && sum <= 10) {
                smallCount += 1;
            }
            //单
            if (sum === 5 || sum === 7 || sum === 9 || sum === 11 || sum === 13 || sum === 15 | sum === 17) {
                oddCount += 1;
            }
            //大，1赔1
            if (sum >= 11 && sum <= 17) {
                bigCount += 1;
            }
            //双
            if (sum === 4 || sum === 6 || sum === 8 || sum === 10 || sum === 12 || sum === 14 | sum === 16) {
                evenCount += 1;
            }
            if (!statsObj.hasOwnProperty(sum)) {
                statsObj[sum] = 1;
            } else {
                statsObj[sum] += 1;
            }
            //猜数字，1赔1
            if (i === 1 || j === 1 || k === 1) {
                guessNumber += 1;
            }
            //三个数字相同，豹子，1赔150
            if (i === j && j === k && i === 1) {
                threeSame += 1;
            }
        }
    }
}
console.log(`small: ${smallCount},odd:${oddCount},big:${bigCount},even:${evenCount},guessNumber:${guessNumber},threeSame:${threeSame}`);
console.dir(statsObj);
console.log("end");