# Contributing and releases

Keep components independent of any app's resources, models, persistence and permissions.
Use public Monkey C APIs and explicit callbacks. Document new props and theme tokens.
Add behavioral tests for input, state and composition changes. Compile the showcase
for both AMOLED and MIP targets; inspect it in the simulator and on hardware when available.

Before a release:
1. Update version in manifest.xml, scripts/build.sh and README.md.
2. Run build.sh, unit tests and a barrel-integrated consumer build.
3. Review `git ls-files` for keys, generated code and unrelated files.
4. Commit the change, create an annotated version tag and push it.
5. Create a GitHub Release and attach only the reusable `.barrel` artifact.

Initial public setup (if publication has not been completed): create a public
GitHub repository named ConnectIQComponents, then run:

```sh
git remote add origin https://github.com/Snikerso/ConnectIQComponents.git
git push -u origin main
git push origin v0.1.0
```
