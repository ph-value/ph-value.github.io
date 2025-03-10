const axios = require('axios');
const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');


// 변환할 폴더 경로 설정 (예: './markdown-files')
const folderPath = './project_info';
const outputFilePath = './project_info/projects.json';

function convertMdFilesToJson(folderPath, outputFilePath) {
  // 폴더 내의 모든 파일 목록을 가져옴
  fs.readdir(folderPath, (err, files) => {
    if (err) {
      console.error('폴더를 읽는 중 오류가 발생했습니다:', err);
      return;
    }

    const mdFiles = files.filter(file => path.extname(file) === '.md');

    const jsonArray = [];

    mdFiles.forEach(file => {
      const filePath = path.join(folderPath, file);

      // 파일 읽기
      const content = fs.readFileSync(filePath, 'utf-8');

     // 파일명을 .md 확장자 없이 가져오기
      const fileNameWithoutExt = path.basename(file, '.md');

      // 파일 내용을 JSON 객체로 변환
      jsonArray.push({
        filename: fileNameWithoutExt,
        content: content
      });
    });

    // JSON 파일로 저장
    fs.writeFileSync(outputFilePath, JSON.stringify(jsonArray, null, 2), 'utf-8');
    console.log(`JSON 파일로 변환되었습니다: ${outputFilePath}`);
  });
}

// 함수 실행
convertMdFilesToJson(folderPath, outputFilePath);
