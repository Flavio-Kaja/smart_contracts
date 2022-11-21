const Administration = artifacts.require("Administration");
const School = artifacts.require("School");

module.exports = function (deployer) {
  // Use deployer to initialize migration tasks.
  deployer.deploy(Administration);
  
  deployer.deploy(School);
};
