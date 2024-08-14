const axios = require('axios');
const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');

// GitHub API 요청 설정
const USERNAME = 'ph-value'; // GitHub 사용자명
const REPO = 'ph-value.github.io'; // 레포지토리 이름
const DIR = 'post'; // posts 디렉토리 경로

const url = `https://api.github.com/repos/${USERNAME}/${REPO}/contents/${DIR}`;

axios.get(url, {
  headers: {
    'Accept': 'application/vnd.github.v3+json',
    // 필요하다면 Authorization 헤더에 토큰 추가
  }
})
.then(async response => {
  const files = [];

  for (const file of response.data) {
    if (file.type === 'file' && file.name.endsWith('.md')) {
      const contentResponse = await axios.get(file.download_url);
      const content = contentResponse.data;

       // Front Matter 추출을 위한 정규식
       const frontMatterMatch = content.match(/^---\s*[\r\n]+([\s\S]*?)\s*---/);

      let frontMatter = {};
      let bodyContent = content;

      if (frontMatterMatch) {
          try {
            frontMatter = yaml.load(frontMatterMatch[1]);
            // 프론트 매터 부분을 제외한 나머지 내용을 추출
            bodyContent = content.slice(frontMatterMatch[0].length).trim();
          } catch (e) {
            console.error(`Error parsing front matter in ${file.name}:`, e);
          }
      }



      files.push({
        name: file.name,
        path: file.path,
        download_url: file.download_url,
        frontMatter: frontMatter,
        content: bodyContent,
      });
    }
  }

  const outputPath = path.join(__dirname, 'post', 'files.json');

  // 디렉토리가 없으면 생성
  const dir = path.dirname(outputPath);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }

  // JSON 파일로 저장
  fs.writeFileSync(outputPath, JSON.stringify(files, null, 2));
  console.log(`File list saved to ${outputPath}`);
})
.catch(error => {
  console.error('Error fetching files:', error);
});
