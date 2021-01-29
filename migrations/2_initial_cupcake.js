const cupcake = artifacts.require("CupCake"); //artifacts.require告诉platon-truffle需要部署哪个合约，HelloWorld即之前写的合约类名
    module.exports = function(deployer) {
	           deployer.deploy(cupcake); //helloWorld即之前定义的合约抽象（部署带参数的合约失败，请参考FAQ部署带参数合约失败说明）
    };
