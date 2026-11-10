import localUnitTest from './LocalUnit.test';
import repositoryTest from './Repository.test';

export default function testsuite() {
  localUnitTest();
  repositoryTest();
}