const abi = require("../build/contracts/CupCake.json")['abi'];
const deployAddress = 'atp1zkrxx6rf358jcvr7nruhyvr9hxpwv9uncjmns0'; // cupcake合约部署者钱包地址(根据实际情况修改)
const contractAddress = 'atp195ulq6djvcpr358jhf20g5qser555ykcqxrml3'; // cupcake合约地址(根据实际情况修改)
const ownerAddr = 'atp13emr62l74v9uevxw4sny8mnlv8npwml07emqtc'; // 合约owner新地址(根据实际情况修改)

module.exports = async function(deployer, network, accounts) {
  
	
  var cupcake = new web3.platon.Contract(abi,contractAddress, {net_type:"atp"});

  await cupcake.methods.setOwner(ownerAddr).send({from: deployAddress, gas: 4500000});

  var newOwner = await cupcake.methods.owner().call();
   if(newOwner != ownerAddr){
       console.log(newOwner," ownwe 设置失败！");
   }else{
       console.log(newOwner," ownwe 设置成功！");
   }
};
