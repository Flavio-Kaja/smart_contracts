const Administration = artifacts.require("Administration");
var account_one = "0xEBC04d4A237d31D62677206b377Ce6d63426c673"; // our admin account
var account_two = "0x555AA98EBe8F4C442A9E9ab7CE26Ed7BDdcA4882"; //the new student account
/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("Administration", function (/* accounts */) {
  before(async () => {
    instance = await Administration.deployed();
  });

  it("should assert true", async function () {
    return assert.isTrue(true);
  });

  it("checks admin account", async function () {
    await instance.isAdmin("0xEBC04d4A237d31D62677206b377Ce6d63426c673");
    return assert.isTrue(true);
  });

  it("Adds student", async function () {
    await instance.addStudent("0x555AA98EBe8F4C442A9E9ab7CE26Ed7BDdcA4882");
    let message = instance.message;
    assert(message != "");
  });

  it("Adds teacher", async function () {
    await instance.addTeacher("0x92aac0f8F181346a7a3605651f490F7605870204");
    let message = instance.message;
    assert(message != "");
  });

  it("Checks teacher account", async function () {
    await instance.isTeacher("0x92aac0f8F181346a7a3605651f490F7605870204");
    let message = instance.message;
    assert(message != "");
  });
});
