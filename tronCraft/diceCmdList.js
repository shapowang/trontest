let result = tokenContract.updateMinerCFTAddr("TVdX435jKc6KjoYYdTF4ZjiHizj14U4LX6").send({shouldPollResponse: true}).then(function (e) {
    console.log(e);
});
console.log(result);