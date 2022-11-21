const School = artifacts.require("School");
const Administration = artifacts.require("Administration");
/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("School", function (/* accounts */) {
  before(async () => {
    let admin = await Administration.deployed();
    instance = await School.deployed();
    instance.administration = admin;
  });

  it("School Contract deployed", async function () {
    await School.deployed();
    return assert.isTrue(true);
  });

  it("Adds Study program", async function () {
    instance = await School.deployed();
    let result = await instance.addNewStudyProgram(
      "0x427573696e65737320496e666f726d6174696373", //Business Informatics
      [
        "0x4d6163726f65636f6e6f6d696373", //Macroeconomics
        "0x53746174697374696373", //Statistics
        "0x53746174697374696373", // Programming in Java
        "0x416c676f726974686d73", //Algorithms
        "0x446174612053747275637475726573", //Data Structures
        "0x4f7065726174696e672053797374656d73", //Operating Systems
        "0x50726f6772616d6d696e6720696e20432b2b", //Programming in C++
        "0x4c696e65617220416c6765627261", //Linear Algebra
        "0x4d6963726f65636f6e6f6d696373", //Microeconomics
        "0x456e74727920746f2045636f6e6f6d696373", //Entry to Economics
        "0x456e74727920746f20496e666f726d6174696373", //Entry to Informatics
        "0x4170706c696564204d617468656d6174696373", //Applied Mathematics
      ]
    );
    assert.isTrue(result != null);
  });

  it("Sudent registered to program", async function () {
    instance = await School.deployed();

    await instance.addStudent(
      "0x555AA98EBe8F4C442A9E9ab7CE26Ed7BDdcA4882",
      "0x427573696e65737320496e666f726d6174696373"
    );
    return assert.isTrue(true);
  });
});
