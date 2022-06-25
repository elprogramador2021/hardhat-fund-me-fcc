//import
//main function
//calling of main function
/*
function deployFunc() {
    console.log("Hi!")
}

module.exports.default = deployFunc
*/

//hre - hardhat runtime environment
/*
module.exports = async (hre) => {
    const { getNamedAccounts, deployments } = hre
}
*/

const { networkConfig, developmentChains } = require("../helper-hardhat-config")
const { network } = require("hardhat")
const { verify } = require("../utils/verify") //<------

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId

    //If ChainId is X use address Y
    let ethUsdPriceFeedAddress
    if (developmentChains.includes(network.name)) {
        const ethUsdAggregator = await deployments.get("MockV3Aggregator")
        ethUsdPriceFeedAddress = ethUsdAggregator.address
    } else {
        ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"]
    }

    //MOCKING
    //If the contract doesn't exist, we deploy a minimal version for our local testing

    //well what happens when we want to change chains?
    //when going for localhost or hardhat network we want to use a mock
    const args = [ethUsdPriceFeedAddress] //<-----------------

    const fundMe = await deploy("FundMe", {
        from: deployer,
        args: args, //put price feed address
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })

    //IF NOT LOCAL VERIFY
    if (
        !developmentChains.includes(network.name) &&
        process.env.ETHERSCAN_API_KEY
    ) {
        //verify
        await verify(fundMe.address, args)
    }

    log("-----------------------------------------------")
}

module.exports.tags = ["all", "fundme"]
