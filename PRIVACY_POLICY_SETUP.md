# How to Host Your Privacy Policy

## Step 1: Customize the Privacy Policy

1. Open `PRIVACY_POLICY.md` in this folder
2. Replace `[YOUR_EMAIL@example.com]` with your actual support email
3. Review all sections and customize as needed for your app

## Step 2: Host the Privacy Policy (Choose One Method)

### Option A: GitHub Pages (Recommended - Free & Easy)

1. Create a new GitHub repository (or use your existing betcha_flutter repo)
2. Go to repository Settings > Pages
3. Create a new file in your repo: `privacy-policy.html`
4. Convert the markdown to HTML (use https://markdowntohtml.com/)
5. Paste the HTML into `privacy-policy.html`
6. Enable GitHub Pages from Settings > Pages
7. Your URL will be: `https://[your-username].github.io/[repo-name]/privacy-policy.html`

**Quick Commands:**
```bash
cd C:\Users\charl\Downloads\Development\betcha_flutter

# Initialize git if not already done
git init

# Create a docs folder for GitHub Pages
mkdir docs
copy PRIVACY_POLICY.md docs\privacy-policy.md

# You'll need to convert to HTML and commit
# Then enable GitHub Pages in your repo settings
```

### Option B: Google Sites (Free - No Coding Required)

1. Go to https://sites.google.com/
2. Click "Create" (bottom right)
3. Choose "Blank" template
4. Copy and paste your privacy policy text
5. Click "Publish" (top right)
6. Choose a URL like `betcha-privacy.sites.google.com`
7. Click "Publish"
8. Your URL will be provided

### Option C: Host on Your Own Website

If you have your own website, upload the privacy policy there:
- URL example: `https://yourdomain.com/privacy-policy.html`

## Step 3: Add to Google Play Console

1. Go to [Google Play Console](https://play.google.com/console)
2. Select your app (com.mashkdev.friendlywager)
3. Navigate to **Policy** → **App content** (left sidebar)
4. Find **Privacy Policy** section
5. Click "Start" or "Edit"
6. Enter your Privacy Policy URL
7. Click "Save"

## Step 4: Complete Other Required Declarations

While you're in the App Content section, you may also need to fill out:

- **Data Safety Form:** Declare what data you collect
  - User account info (email, username)
  - Photos and videos (optional - user choice)
  - App activity (bets, social interactions)

- **Target Audience:**
  - Age: 18+ (gambling/betting content)

- **Content Ratings:**
  - Complete the rating questionnaire

- **Ads:**
  - Declare if you show ads (No for now)

## Step 5: Submit for Review

Once you've added the privacy policy URL and completed all required forms, you can submit your app bundle for review.

## Quick Check

Before submitting, verify:
- [ ] Privacy policy is publicly accessible
- [ ] Privacy policy URL is added to Google Play Console
- [ ] All permissions (CAMERA, etc.) are explained in the policy
- [ ] Contact email is correct
- [ ] Data Safety form is completed
- [ ] App content rating is completed

---

**Need Help?**
If you get stuck, the Google Play Console will show you which sections are required with red exclamation marks.
