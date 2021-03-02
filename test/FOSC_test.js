require('chai').should();
const { expect, assert } = require('chai');
const {
    BN,
    expectEvent,
    expectRevert,
    constants
} = require('@openzeppelin/test-helpers');
const { accounts, contract } = require('@openzeppelin/test-environment');
const { ZERO_ADDRESS } = constants;
const FOSC = contract.fromArtifact('FOSC');

describe("FOSC Contract", function () {
    let fosc;
    const [
        callValue,
        owner,
        oracleAddress,
        newOracleAddress,
        nonOwner
    ] = accounts;

    describe("Constructor:", function () {
        it("Oracle address is required", async function () {
            await expectRevert(FOSC.new(ZERO_ADDRESS, callValue, { from: owner }).then(() => done()),
                "New oracle address is required"
            );
        });

        it("Call value must be > 0", async function () {
            await expectRevert(FOSC.new(oracleAddress, 0, { from: owner }).then(() => done()),
                "Call value must be greater than 0"
            );
        })
    });

    describe("Contract functions:", function () {
        before(async function () {
            fosc = await FOSC.new(oracleAddress, callValue, { from: owner });
        });

        it("Only Owner can execute setOracle function", async () => {
            await expectRevert(fosc.setOracle(ZERO_ADDRESS, { from: owner }),
                "New oracle address is required"
            );
            await expectRevert(fosc.setOracle(newOracleAddress, { from: nonOwner }),
                "Ownable: caller is not the owner"
            );
            await fosc.setOracle(newOracleAddress, { from: owner });
        });

        it("Function to test Generated Call ID are unique", async function () {
            // TODO: need to figure out how to put this two transactions in one block
            // Check nonce value
            expect(await fosc.nonce.call()).to.be.bignumber.equal("0");
            // Preview the return value without modifying the state
            const ret1 = await fosc.generateCallId.call();
            // Perform the state transition
            await fosc.generateCallId();

            // Check nonce value
            expect(await fosc.nonce.call()).to.be.bignumber.equal("1");
            // Preview the return value without modifying the state
            const ret2 = await fosc.generateCallId.call();
            // Perform the state transition
            await fosc.generateCallId();

            // Check nonce value
            expect(await fosc.nonce.call()).to.be.bignumber.equal("2");
            // Check if Call_IDs are different
            assert.notEqual(ret1, ret2, "Generated Id's are not EQUAL");
        });
    });
});