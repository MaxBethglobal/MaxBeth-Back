const { expect } = require("chai");
const { ethers } = require("hardhat");

let betting;

beforeEach(async function () {
  const Betting = await ethers.getContractFactory("Betting");
  betting = await Betting.deploy(
    "URL",
    [1, 2],
    [
      [1, 2],
      [3, 4],
    ]
  );
  await betting.deployed();
});

describe("Betting", function () {
  xit("Should return status", async function () {
    expect(await betting.bettingEvents(1).status).to.equal(1);

    // const setBettingTx = await betting.setGreeting("Hola, mundo!");

    // wait until the transaction is mined
    // await setBettingTx.wait();

    // expect(await betting.greet()).to.equal("Hola, mundo!");
  });

  it("Should revert", async function () {
    // const msg =
    await expect(betting.computeWinnings(1, 1)).to.be.reverted;
    // console.log(msg);
    // const setBettingTx = await betting.setGreeting("Hola, mundo!");

    // wait until the transaction is mined
    // await setBettingTx.wait();

    // expect(await betting.greet()).to.equal("Hola, mundo!");
  });
});
