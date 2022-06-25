const { getNamedAccounts, ethers, network } = require("hardhat")
const { developmentChains } = require("../../helper-hardhat-config")
const { assert } = require("chai")

developmentChains.includes(network.name) //<---- only run on test nets
    ? describe.skip
    : describe("FundMe", async function () {
          let fundMe
          let deployer
          //const sendValue = ethers.utils.parseEther("1")
          //171300000000000000
          const sendValue = "10000000000000000"
          beforeEach(async function () {
              deployer = (await getNamedAccounts()).deployer
              fundMe = await ethers.getContract("FundMe", deployer)
              //staging test we're assumming it's already deployed
              //We don't need a Mock, we're assumming we're on a test net
          })

          it("allows people to fund and withdraw", async function () {
              await fundMe.fund({ value: sendValue })
              await fundMe.withdraw()
              const endingFundMeBalance = await fundMe.provider.getBalance(
                  fundMe.address
              )

              console.log(
                  endingFundMeBalance.toString() +
                      " should equal 0, running assert equal..."
              )
              assert.equal(endingFundMeBalance.toString(), "0")
          })
      })
