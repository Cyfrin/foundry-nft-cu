// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {DeployMoodNft} from "../script/DeployMoodNft.s.sol";
import {MoodNft} from "../src/MoodNft.sol";
import {Test, console} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {MintBasicNft} from "../script/Interactions.s.sol";
import {ZkSyncChainChecker} from "lib/foundry-devops/src/ZkSyncChainChecker.sol";
import {FoundryZkSyncChecker} from "lib/foundry-devops/src/FoundryZkSyncChecker.sol";

contract MoodNftTest is Test, ZkSyncChainChecker, FoundryZkSyncChecker {
    string constant NFT_NAME = "Mood NFT";
    string constant NFT_SYMBOL = "MN";
    MoodNft public moodNft;
    DeployMoodNft public deployer;
    address public deployerAddress;

    string public constant HAPPY_MOOD_URI =
        "data:application/json;base64,eyJuYW1lIjoiTW9vZCBORlQiLCAiZGVzY3JpcHRpb24iOiJBbiBORlQgdGhhdCByZWZsZWN0cyB0aGUgbW9vZCBvZiB0aGUgb3duZXIsIDEwMCUgb24gQ2hhaW4hIiwgImF0dHJpYnV0ZXMiOiBbeyJ0cmFpdF90eXBlIjogIm1vb2RpbmVzcyIsICJ2YWx1ZSI6IDEwMH1dLCAiaW1hZ2UiOiJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFBITjJaeUIyYVdWM1FtOTRQU0l3SURBZ01qQXdJREl3TUNJZ2QybGtkR2c5SWpRd01DSWdJR2hsYVdkb2REMGlOREF3SWlCNGJXeHVjejBpYUhSMGNEb3ZMM2QzZHk1M015NXZjbWN2TWpBd01DOXpkbWNpUGdvZ0lEeGphWEpqYkdVZ1kzZzlJakV3TUNJZ1kzazlJakV3TUNJZ1ptbHNiRDBpZVdWc2JHOTNJaUJ5UFNJM09DSWdjM1J5YjJ0bFBTSmliR0ZqYXlJZ2MzUnliMnRsTFhkcFpIUm9QU0l6SWk4K0NpQWdQR2NnWTJ4aGMzTTlJbVY1WlhNaVBnb2dJQ0FnUEdOcGNtTnNaU0JqZUQwaU56QWlJR041UFNJNE1pSWdjajBpTVRJaUx6NEtJQ0FnSUR4amFYSmpiR1VnWTNnOUlqRXlOeUlnWTNrOUlqZ3lJaUJ5UFNJeE1pSXZQZ29nSUR3dlp6NEtJQ0E4Y0dGMGFDQmtQU0p0TVRNMkxqZ3hJREV4Tmk0MU0yTXVOamtnTWpZdU1UY3ROalF1TVRFZ05ESXRPREV1TlRJdExqY3pJaUJ6ZEhsc1pUMGlabWxzYkRwdWIyNWxPeUJ6ZEhKdmEyVTZJR0pzWVdOck95QnpkSEp2YTJVdGQybGtkR2c2SURNN0lpOCtDand2YzNablBnbz0ifQ==";

    string public constant SAD_MOOD_URI =
        "data:application/json;base64,eyJuYW1lIjoiTW9vZCBORlQiLCAiZGVzY3JpcHRpb24iOiJBbiBORlQgdGhhdCByZWZsZWN0cyB0aGUgbW9vZCBvZiB0aGUgb3duZXIsIDEwMCUgb24gQ2hhaW4hIiwgImF0dHJpYnV0ZXMiOiBbeyJ0cmFpdF90eXBlIjogIm1vb2RpbmVzcyIsICJ2YWx1ZSI6IDEwMH1dLCAiaW1hZ2UiOiJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFBITjJaeUIzYVdSMGFEMGlNVEF5TkhCNElpQm9aV2xuYUhROUlqRXdNalJ3ZUNJZ2RtbGxkMEp2ZUQwaU1DQXdJREV3TWpRZ01UQXlOQ0lnZUcxc2JuTTlJbWgwZEhBNkx5OTNkM2N1ZHpNdWIzSm5Mekl3TURBdmMzWm5JajRLSUNBOGNHRjBhQ0JtYVd4c1BTSWpNek16SWlCa1BTSk5OVEV5SURZMFF6STJOQzQySURZMElEWTBJREkyTkM0MklEWTBJRFV4TW5NeU1EQXVOaUEwTkRnZ05EUTRJRFEwT0NBME5EZ3RNakF3TGpZZ05EUTRMVFEwT0ZNM05Ua3VOQ0EyTkNBMU1USWdOalI2YlRBZ09ESXdZeTB5TURVdU5DQXdMVE0zTWkweE5qWXVOaTB6TnpJdE16Y3ljekUyTmk0MkxUTTNNaUF6TnpJdE16Y3lJRE0zTWlBeE5qWXVOaUF6TnpJZ016Y3lMVEUyTmk0MklETTNNaTB6TnpJZ016Y3llaUl2UGdvZ0lEeHdZWFJvSUdacGJHdzlJaU5GTmtVMlJUWWlJR1E5SWswMU1USWdNVFF3WXkweU1EVXVOQ0F3TFRNM01pQXhOall1Tmkwek56SWdNemN5Y3pFMk5pNDJJRE0zTWlBek56SWdNemN5SURNM01pMHhOall1TmlBek56SXRNemN5TFRFMk5pNDJMVE0zTWkwek56SXRNemN5ZWsweU9EZ2dOREl4WVRRNExqQXhJRFE0TGpBeElEQWdNQ0F4SURrMklEQWdORGd1TURFZ05EZ3VNREVnTUNBd0lERXRPVFlnTUhwdE16YzJJREkzTW1ndE5EZ3VNV010TkM0eUlEQXROeTQ0TFRNdU1pMDRMakV0Tnk0MFF6WXdOQ0EyTXpZdU1TQTFOakl1TlNBMU9UY2dOVEV5SURVNU4zTXRPVEl1TVNBek9TNHhMVGsxTGpnZ09EZ3VObU10TGpNZ05DNHlMVE11T1NBM0xqUXRPQzR4SURjdU5FZ3pOakJoT0NBNElEQWdNQ0F4TFRndE9DNDBZelF1TkMwNE5DNHpJRGMwTGpVdE1UVXhMallnTVRZd0xURTFNUzQyY3pFMU5TNDJJRFkzTGpNZ01UWXdJREUxTVM0MllUZ2dPQ0F3SURBZ01TMDRJRGd1TkhwdE1qUXRNakkwWVRRNExqQXhJRFE0TGpBeElEQWdNQ0F4SURBdE9UWWdORGd1TURFZ05EZ3VNREVnTUNBd0lERWdNQ0E1Tm5vaUx6NEtJQ0E4Y0dGMGFDQm1hV3hzUFNJak16TXpJaUJrUFNKTk1qZzRJRFF5TVdFME9DQTBPQ0F3SURFZ01DQTVOaUF3SURRNElEUTRJREFnTVNBd0xUazJJREI2YlRJeU5DQXhNVEpqTFRnMUxqVWdNQzB4TlRVdU5pQTJOeTR6TFRFMk1DQXhOVEV1Tm1FNElEZ2dNQ0F3SURBZ09DQTRMalJvTkRndU1XTTBMaklnTUNBM0xqZ3RNeTR5SURndU1TMDNMalFnTXk0M0xUUTVMalVnTkRVdU15MDRPQzQySURrMUxqZ3RPRGd1Tm5NNU1pQXpPUzR4SURrMUxqZ2dPRGd1Tm1NdU15QTBMaklnTXk0NUlEY3VOQ0E0TGpFZ055NDBTRFkyTkdFNElEZ2dNQ0F3SURBZ09DMDRMalJETmpZM0xqWWdOakF3TGpNZ05UazNMalVnTlRNeklEVXhNaUExTXpONmJURXlPQzB4TVRKaE5EZ2dORGdnTUNBeElEQWdPVFlnTUNBME9DQTBPQ0F3SURFZ01DMDVOaUF3ZWlJdlBnbzhMM04yWno0SyJ9";

    address public constant USER = address(1);

    function setUp() public {
        deployer = new DeployMoodNft();
        if (!isZkSyncChain()) {
            moodNft = deployer.run();
        } else {
            string memory sadSvg = vm.readFile("./images/dynamicNft/sad.svg");
            string memory happySvg = vm.readFile("./images/dynamicNft/happy.svg");
            moodNft = new MoodNft(deployer.svgToImageURI(sadSvg), deployer.svgToImageURI(happySvg));
        }
    }

    function testInitializedCorrectly() public view {
        assert(keccak256(abi.encodePacked(moodNft.name())) == keccak256(abi.encodePacked((NFT_NAME))));
        assert(keccak256(abi.encodePacked(moodNft.symbol())) == keccak256(abi.encodePacked((NFT_SYMBOL))));
    }

    function testCanMintAndHaveABalance() public {
        vm.prank(USER);
        moodNft.mintNft();

        assert(moodNft.balanceOf(USER) == 1);
    }

    function testTokenURIDefaultIsCorrectlySet() public {
        vm.prank(USER);
        moodNft.mintNft();

        assert(keccak256(abi.encodePacked(moodNft.tokenURI(0))) == keccak256(abi.encodePacked(HAPPY_MOOD_URI)));
    }

    function testFlipTokenToSad() public {
        vm.prank(USER);
        moodNft.mintNft();

        vm.prank(USER);
        moodNft.flipMood(0);

        assert(keccak256(abi.encodePacked(moodNft.tokenURI(0))) == keccak256(abi.encodePacked(SAD_MOOD_URI)));
    }

    // logging events doesn't work great in foundry-zksync
    function testEventRecordsCorrectTokenIdOnMinting() public onlyVanillaFoundry {
        uint256 currentAvailableTokenId = moodNft.getTokenCounter();

        vm.prank(USER);
        vm.recordLogs();
        moodNft.mintNft();
        Vm.Log[] memory entries = vm.getRecordedLogs();

        bytes32 tokenId_proto = entries[1].topics[1];
        uint256 tokenId = uint256(tokenId_proto);

        assertEq(tokenId, currentAvailableTokenId);
    }
}
