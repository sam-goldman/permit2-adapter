Follow these instructions to deploy the `UniversalPermit2Adapter` with Sphinx on a couple testnets.
It should take you 5-10 minutes to finish.

1. Clone this fork of your repo:
```
git clone git@github.com:sam-goldman/permit2-adapter.git
```

2.
```
cd permit2-adapter
```

3. Update Foundry, then install packages:
```
foundryup && pnpm install && forge install
```

4. Go to the [Sphinx UI](https://sphinx.dev) to sign up using the invite link I sent in the initial
   message on Telegram. Then, in the website, go to "Options" -> "API Credentials". You'll need
   these credentials in the next couple of steps.

5. Open `script/Base.s.sol`. The `setUp` function contains your config options. Update the following
   fields:\
    a. In `sphinxConfig.orgId`, add the Organization ID from Sphinx's website. This is a public
    field, so you don't need to keep it secret.\
    b. In `sphinxConfig.owners`, add the addresses of the account(s) that will own your project.
    (Specifically, they'll own the Gnosis Safe that executes your deployment).

6. Create a `.env` file. Then, copy and paste the variables below, filling in their values. (The
   `SPHINX_API_KEY` is in the Sphinx UI under "Options" -> "API Credentials").
```
SPHINX_API_KEY="YOUR_API_KEY_SPHINX"
API_KEY_ALCHEMY="YOUR_API_KEY_ALCHEMY"
```

7. You're done with the configuration steps! Run `forge test` to make sure your tests are passing.

8. Next, propose the deployment script on the networks in `sphinxConfig.testnets`:
```
pnpm sphinx propose script/DeployUniversalAdapter.s.sol --networks testnets
```

9. When the proposal is finished, go to the [Sphinx UI](https://sphinx.dev) to approve the
   deployment. After you approve it, you can monitor the deployment's status in the UI while it's
   executed.
